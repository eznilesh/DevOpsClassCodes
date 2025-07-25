#!/bin/bash

# Vaadin Addressbook Performance Testing Script
# Usage: ./performance-test.sh

echo "🚀 Vaadin Addressbook Performance Test"
echo "======================================"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Test 1: Build Performance
echo -e "\n${YELLOW}📦 Testing Build Performance...${NC}"
BUILD_START=$(date +%s)
mvn clean package -DskipTests -q
BUILD_END=$(date +%s)
BUILD_TIME=$((BUILD_END - BUILD_START))

if [ $BUILD_TIME -lt 30 ]; then
    echo -e "${GREEN}✅ Build Time: ${BUILD_TIME}s (Excellent)${NC}"
elif [ $BUILD_TIME -lt 60 ]; then
    echo -e "${YELLOW}⚠️  Build Time: ${BUILD_TIME}s (Good)${NC}"
else
    echo -e "${RED}❌ Build Time: ${BUILD_TIME}s (Needs Improvement)${NC}"
fi

# Test 2: Bundle Size Analysis
echo -e "\n${YELLOW}📊 Bundle Size Analysis...${NC}"
if [ -f "target/addressbook.war" ]; then
    WAR_SIZE=$(du -h target/addressbook.war | cut -f1)
    WAR_SIZE_BYTES=$(du -b target/addressbook.war | cut -f1)
    
    echo "📄 WAR File Size: $WAR_SIZE"
    
    # Size thresholds (in bytes)
    EXCELLENT_THRESHOLD=8388608  # 8MB
    GOOD_THRESHOLD=13631488      # 13MB  
    
    if [ $WAR_SIZE_BYTES -lt $EXCELLENT_THRESHOLD ]; then
        echo -e "${GREEN}✅ Bundle Size: Excellent (<8MB)${NC}"
    elif [ $WAR_SIZE_BYTES -lt $GOOD_THRESHOLD ]; then
        echo -e "${YELLOW}⚠️  Bundle Size: Good (<13MB)${NC}"
    else
        echo -e "${RED}❌ Bundle Size: Needs Optimization (>13MB)${NC}"
    fi
    
    # File count analysis
    FILE_COUNT=$(unzip -l target/addressbook.war | tail -1 | awk '{print $2}')
    echo "📁 Total Files in WAR: $FILE_COUNT"
    
    # Largest dependencies
    echo -e "\n📦 Top 5 Largest Dependencies:"
    unzip -l target/addressbook.war | grep "\.jar" | sort -k1 -n | tail -5 | awk '{printf "   %8s  %s\n", $1, $4}'
    
else
    echo -e "${RED}❌ WAR file not found. Build may have failed.${NC}"
fi

# Test 3: Dependency Analysis
echo -e "\n${YELLOW}🔍 Dependency Analysis...${NC}"
if [ -f "target/addressbook.war" ]; then
    COMPATIBILITY_JARS=$(unzip -l target/addressbook.war | grep -c "compatibility")
    SASS_JARS=$(unzip -l target/addressbook.war | grep -c "sass")
    SOURCE_JARS=$(unzip -l target/addressbook.war | grep -c "sources\.jar")
    
    if [ $COMPATIBILITY_JARS -eq 0 ]; then
        echo -e "${GREEN}✅ No compatibility JARs (optimized)${NC}"
    else
        echo -e "${RED}❌ Found $COMPATIBILITY_JARS compatibility JARs${NC}"
    fi
    
    if [ $SASS_JARS -eq 0 ]; then
        echo -e "${GREEN}✅ No SASS compiler JARs (optimized)${NC}"
    else
        echo -e "${RED}❌ Found $SASS_JARS SASS JARs${NC}"
    fi
    
    if [ $SOURCE_JARS -eq 0 ]; then
        echo -e "${GREEN}✅ No source JARs (optimized)${NC}"
    else
        echo -e "${RED}❌ Found $SOURCE_JARS source JARs${NC}"
    fi
fi

# Test 4: Configuration Verification
echo -e "\n${YELLOW}⚙️  Configuration Verification...${NC}"

# Check production mode
if grep -q "productionMode = true" src/main/java/com/edurekademo/tutorial/addressbook/AddressbookUI.java; then
    echo -e "${GREEN}✅ Production mode enabled${NC}"
else
    echo -e "${RED}❌ Production mode disabled${NC}"
fi

# Check heartbeat optimization
if grep -q "heartbeatInterval" src/main/java/com/edurekademo/tutorial/addressbook/AddressbookUI.java; then
    echo -e "${GREEN}✅ Heartbeat interval optimized${NC}"
else
    echo -e "${RED}❌ Heartbeat interval not optimized${NC}"
fi

# Check widgetset optimization
if grep -q "DefaultWidgetSet" src/main/java/com/edurekademo/tutorial/addressbook/AddressbookUI.java; then
    echo -e "${GREEN}✅ Using optimized widgetset${NC}"
else
    echo -e "${RED}❌ Using compatibility widgetset${NC}"
fi

# Test 5: Performance Score
echo -e "\n${YELLOW}🏆 Performance Score Calculation...${NC}"
SCORE=0

# Build time score (40 points max)
if [ $BUILD_TIME -lt 20 ]; then SCORE=$((SCORE + 40))
elif [ $BUILD_TIME -lt 30 ]; then SCORE=$((SCORE + 30))
elif [ $BUILD_TIME -lt 60 ]; then SCORE=$((SCORE + 20))
else SCORE=$((SCORE + 10))
fi

# Bundle size score (40 points max)
if [ $WAR_SIZE_BYTES -lt $EXCELLENT_THRESHOLD ]; then SCORE=$((SCORE + 40))
elif [ $WAR_SIZE_BYTES -lt $GOOD_THRESHOLD ]; then SCORE=$((SCORE + 30))
else SCORE=$((SCORE + 15))
fi

# Configuration score (20 points max)
if grep -q "productionMode = true" src/main/java/com/edurekademo/tutorial/addressbook/AddressbookUI.java; then
    SCORE=$((SCORE + 10))
fi
if grep -q "DefaultWidgetSet" src/main/java/com/edurekademo/tutorial/addressbook/AddressbookUI.java; then
    SCORE=$((SCORE + 10))
fi

echo "🎯 Performance Score: $SCORE/100"

if [ $SCORE -ge 80 ]; then
    echo -e "${GREEN}🌟 Excellent Performance! 🌟${NC}"
elif [ $SCORE -ge 60 ]; then
    echo -e "${YELLOW}⭐ Good Performance ⭐${NC}"
else
    echo -e "${RED}🔧 Needs Optimization 🔧${NC}"
fi

# Recommendations
echo -e "\n${YELLOW}💡 Optimization Recommendations:${NC}"
if [ $WAR_SIZE_BYTES -gt $EXCELLENT_THRESHOLD ]; then
    echo "   📉 Consider implementing custom widgetset to reduce bundle size"
    echo "   🎨 Switch to minimal theme instead of full Valo theme"
fi

if [ $BUILD_TIME -gt 30 ]; then
    echo "   ⚡ Increase Maven memory allocation for faster builds"
    echo "   🔧 Consider dependency cleanup for faster resolution"
fi

echo -e "\n${GREEN}📋 Test completed! Check performance-benchmark.md for detailed optimizations.${NC}"